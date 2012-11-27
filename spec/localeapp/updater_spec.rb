require 'spec_helper'

describe Localeapp::Updater, ".update(data)" do
  before(:each) do
    @yml_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'fixtures', '*.yml')).each { |f| FileUtils.cp f, @yml_dir }
    with_configuration(:translation_data_directory => @yml_dir) do
      @updater = Localeapp::Updater.new
    end
  end

  after(:each) do
    FileUtils.rm_rf @yml_dir
  end

  def do_update(data)
    @updater.update(data)
  end

  def load_yaml(locale)
    YAML.load(File.read(File.join(@yml_dir, "#{locale}.yml")))
  end

  it "adds, updates and deletes keys in the yml files" do
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

    load_yaml('en').should == {
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
    }
  end

  it "deletes keys in the yml files when updates are empty" do
    do_update({
      'translations' => {},
      'deleted' => [
        'foo.delete_me',
        'bar.delete_me_too',
        'hah.imnotreallyhere'
      ],
      'locales' => %w{es}
    })

    load_yaml('es').should == {
      'es' => {
        'foo' => {
          'monkey' => 'Mono'
        }
      }
    }
  end

  it "creates a new yml file if an unknown locale is passed" do
    do_update({
      'translations' => {
        'ja' => { 'foo' => 'bar'}
      },
      'locales' => ['ja']
    })

    load_yaml('ja').should == {
      'ja' => {
        'foo' => 'bar'
      }
    }
  end

  it "doesn't create a new yml file if an unknown locale is passed but it has no translations" do
    do_update({
      'translations' => {},
      'deleted' => ['foo.delete_me'],
      'locales' => ['ja']
    })
    File.exist?(File.join(@yml_dir, 'ja.yml')).should be_false
  end

  if defined?(Psych) && Psych::VERSION >= "1.1.0"
    it "doesn't try to wrap long lines in the output" do
      do_update({
        'translations' => {
          'en' => { 'foo' => ('bar ' * 30) }
         },
         'locales' => ['en'],
         'deleted' => []
      })
      File.read(File.join(@yml_dir, 'en.yml')).should match(/foo: ! 'bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar bar '/m)
    end
  end

  it "doesn't change a yml file's permissions" do
    filepath = File.join(@yml_dir, 'en.yml')
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

  it "creates new yml files chmodded with 644" do
    do_update({
      'translations' => {
        'ja' => { 'foo' => 'bar'}
      },
      'locales' => ['ja']
    })
    mode = File.stat(File.join(@yml_dir, 'ja.yml')).mode # octal
    mode.to_s(8)[3, 3].should == "644"
  end
end

describe Localeapp::Updater, ".dump(data)" do
  before(:each) do
    @yml_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'fixtures', '*.yml')).each { |f| FileUtils.cp f, @yml_dir }
    with_configuration(:translation_data_directory => @yml_dir) do
      @updater = Localeapp::Updater.new
    end
  end

  after(:each) do
    FileUtils.rm_rf @yml_dir
  end

  def do_dump(data)
    @updater.dump(data)
  end

  it "replaces the content of an existing yml file" do
    filepath = File.join(@yml_dir, 'en.yml')
    content = lambda { YAML.load(File.read(filepath)) }
    expect { do_dump({'en' => {'updated' => 'content'}}) }.to change(content, :call).to({
      'en' => {
        'updated' => 'content'
      }
    })
  end

  it "creates a new yml file if an unknown locale is passed" do
    do_dump({'ja' => { 'foo' => 'bar'} })
    YAML.load(File.read(File.join(@yml_dir, 'ja.yml'))).should == {
      'ja' => {
        'foo' => 'bar'
      }
    }
  end

  it "doesn't change a yml file's permissions" do
    filepath = File.join(@yml_dir, 'en.yml')
    File.chmod(0777, filepath)
    permissions = lambda { File.stat(filepath).mode.to_s(8) }
    expect { do_dump({'en' => { 'foo' => 'bar'} }) }.to_not change(permissions, :call)
  end

  it "creates new yml files chmodded with 644" do
    do_dump({'ja' => { 'foo' => 'bar'} })
    mode = File.stat(File.join(@yml_dir, 'ja.yml')).mode # octal
    mode.to_s(8)[3, 3].should == "644"
  end
end
