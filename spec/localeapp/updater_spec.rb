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
    if defined? Psych
      File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en:
  foo:
    monkey: hello
    night: the night
EN
    else
      File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en: 
  foo: 
    monkey: hello
    night: "the night"
EN
    end
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
    if defined? Psych
      File.read(File.join(@yml_dir, 'es.yml')).should == <<-ES
es:
  foo:
    monkey: Mono
ES
    else
      File.read(File.join(@yml_dir, 'es.yml')).should == <<-ES
es: 
  foo: 
    monkey: Mono
ES
    end
  end

  it "creates a new yml file if an unknown locale is passed" do
    do_update({
      'translations' => {
        'ja' => { 'foo' => 'bar'}
      },
      'locales' => ['ja']
    })
    if defined? Psych
      File.read(File.join(@yml_dir, 'ja.yml')).should == <<-JA
ja:
  foo: bar
JA
    else
      File.read(File.join(@yml_dir, 'ja.yml')).should == <<-JA
ja: 
  foo: bar
JA
    end
  end

  it "doesn't create a new yml file if an unknown locale is passed but it has no translations" do
    do_update({
      'translations' => {},
      'deleted' => ['foo.delete_me'],
      'locales' => ['ja']
    })
    File.exist?(File.join(@yml_dir, 'ja.yml')).should be_false
  end
end
