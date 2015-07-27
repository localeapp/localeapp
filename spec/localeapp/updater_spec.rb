require 'spec_helper'

describe Localeapp::Updater, ".update(data)" do
  before do
    @locales_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), *%w[.. fixtures locales *.{json,yml}])).each do |f|
      FileUtils.cp f, @locales_dir
    end
    with_configuration(:translation_data_directory => @locales_dir) do
      @updater = Localeapp::Updater.new
    end
  end

  after(:each) do
    FileUtils.rm_rf @locales_dir
  end

  def do_update(data)
    @updater.update(data)
  end

  def load_json(locale)
    JSON.parse(File.read(File.join(@locales_dir, "#{locale}.json")))
  end

  def load_yaml(locale)
    YAML.load(File.read(File.join(@locales_dir, "#{locale}.yml")))
  end

  [:json, :yaml].each do |format|
    define_method :load_file do |*args|
      send "load_#{format}".to_sym, *args
    end

    context "when #{format.upcase} format is configured" do
      around { |example| with_configuration(format: format) { example.run } }

      it "adds, updates and deletes keys in the #{format} files" do
        do_update({
          'translations' => {
            'en' => {
              'foo' => { 'monkey' => 'hello', 'night' => 'the night' }
            },
            'es' => {
              'foo' => { 'monkey' => 'hola', 'night' => 'noche' }
            }
          },
          'deleted' => [
            'foo.delete_me',
            'bar.delete_me_too',
            'hah.imnotreallyhere'
          ],
          'locales' => %w{en es}
        })

        expect(load_file('en')).to eq({
          'en' => {
            'foo' => {
              'monkey' => 'hello',
              'night' => 'the night'
            },
            'space' => nil,
            'blank' => '',
            'tilde' => nil,
            'scalar1' => nil,
            'scalar2' => nil,
          }
        })
      end

      it "deletes keys in the #{format.upcase} files when updates are empty" do
        do_update({
          'translations' => {},
          'deleted' => [
            'foo.delete_me',
            'bar.delete_me_too',
            'hah.imnotreallyhere'
          ],
          'locales' => %w{es}
        })

        expect(load_file('es')).to eq({
          'es' => {
            'foo' => {
              'monkey' => 'Mono'
            }
          }
        })
      end

      it "creates a new #{format.upcase} file if an unknown locale is passed" do
        do_update({
          'translations' => {
            'ja' => { 'foo' => 'bar'}
          },
          'locales' => ['ja']
        })

        expect(load_file('ja')).to eq({
          'ja' => {
            'foo' => 'bar'
          }
        })
      end

      it "doesn't delete a namespace having the same name as a previously deleted key" do
        do_update({
          'translations' => {
            'az' => {
              'once_deleted' => {
                'but_not' => 'anymore'
              }
            }
          },
          'deleted' => [
            'once_deleted'
          ],
          'locales' => ['az']
        })

        expect(load_file('az')).to eq({
          'az' => {
            'once_deleted' => {
              'but_not' => 'anymore'
            }
          }
        })
      end
    end
  end

  it "doesn't create a new file if an unknown locale is passed but it has no translations" do
    do_update({
      'translations' => {},
      'deleted' => ['foo.delete_me'],
      'locales' => ['ja']
    })
    expect(File.exist?(File.join(@locales_dir, 'ja.yml'))).to be false
  end

  if defined?(Psych) && defined?(Psych::VERSION) && Psych::VERSION >= "1.1.0" && !RUBY_PLATFORM == 'jruby'
    it "doesn't try to wrap long lines in the output" do
      do_update({
        'translations' => {
          'en' => { 'foo' => ('bar ' * 30) }
         },
         'locales' => ['en'],
         'deleted' => []
      })
      expect(File.read(File.join(@locales_dir, 'en.yml'))).to match(/foo: ! 'bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar '/m)
    end
  end

  it "doesn't change a file's permissions" do
    filepath = File.join(@locales_dir, 'en.yml')
    File.chmod(0777, filepath)
    permissions = lambda { File.stat(filepath).mode.to_s(8) }
    expect {
      do_update(
        'translations' => {
          'en' => { 'foo' => 'bar'}
        },
        'locales' => ['en']
      )
    }.to_not change(permissions, :call)
  end

  it "creates new files chmodded with 644" do
    do_update({
      'translations' => {
        'ja' => { 'foo' => 'bar'}
      },
      'locales' => ['ja']
    })
    mode = File.stat(File.join(@locales_dir, 'ja.yml')).mode # octal
    expect(mode.to_s(8)[3, 3]).to eq("644")
  end
end

describe Localeapp::Updater, ".dump(data)" do
  before do
    @locales_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), *%w[.. fixtures locales *.{json,yml}])).each do |f|
      FileUtils.cp f, @locales_dir
    end
    with_configuration(:translation_data_directory => @locales_dir) do
      @updater = Localeapp::Updater.new
    end
  end

  after(:each) do
    FileUtils.rm_rf @locales_dir
  end

  def do_dump(data)
    @updater.dump(data)
  end

  def load_json(locale)
    JSON.parse(File.read(File.join(@locales_dir, "#{locale}.json")))
  end

  def load_yaml(locale)
    YAML.load(File.read(File.join(@locales_dir, "#{locale}.yml")))
  end

  [:json, :yaml].each do |format|
    define_method :load_file do |*args|
      send "load_#{format}".to_sym, *args
    end

    context "when #{format} format is configured" do
      around { |example| with_configuration(format: format) { example.run } }

      it "replaces the content of an existing #{format.upcase} file" do
        content = lambda { load_file "en" }
        expect { do_dump({'en' => {'updated' => 'content'}}) }.to change(content, :call).to({
          'en' => {
            'updated' => 'content'
          }
        })
      end

      it "creates a new #{format.upcase} file if an unknown locale is passed" do
        do_dump({'ja' => { 'foo' => 'bar'} })
        expect(load_file "ja").to eq({
          'ja' => {
            'foo' => 'bar'
          }
        })
      end
    end
  end

  it "doesn't change a file's permissions" do
    filepath = File.join(@locales_dir, 'en.yml')
    File.chmod(0777, filepath)
    permissions = lambda { File.stat(filepath).mode.to_s(8) }
    expect { do_dump({'en' => { 'foo' => 'bar'} }) }.to_not change(permissions, :call)
  end

  it "creates new files chmodded with 644" do
    do_dump({'ja' => { 'foo' => 'bar'} })
    mode = File.stat(File.join(@locales_dir, 'ja.yml')).mode # octal
    expect(mode.to_s(8)[3, 3]).to eq("644")
  end
end
