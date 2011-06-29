require 'spec_helper'

describe LocaleApp::Updater, ".update(data)" do
  before(:each) do
    @yml_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'fixtures', '*.yml')).each { |f| FileUtils.cp f, @yml_dir }
    with_configuration(:translation_data_directory => @yml_dir) do
      @updater = LocaleApp::Updater.new
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
          'foo' => { 'monkey' => 'hello', 'night' => 'night' }
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
    File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en: 
  foo: 
    monkey: hello
    night: night
EN
    File.read(File.join(@yml_dir, 'es.yml')).should == <<-ES
es: 
  foo: 
    monkey: hola
    night: noche
ES
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
    File.read(File.join(@yml_dir, 'es.yml')).should == <<-ES
es: 
  foo: 
    monkey: Mono
ES
  end

  it "creates a new yml file if an unknown locale is passed" do
    do_update({
      'translations' => {
        'ja' => { 'foo' => 'bar'}
      },
      'locales' => ['ja']
    })
    File.read(File.join(@yml_dir, 'ja.yml')).should == <<-JA
ja: 
  foo: bar
JA
  end

  it "doesn't create a new yml file if an unknown locale is passed but it has no translations" do
    do_update({
      'translations' => {},
      'deletes' => ['foo.delete_me'],
      'locales' => ['ja']
    })
    File.exist?(File.join(@yml_dir, 'ja.yml')).should be_false
  end
end
