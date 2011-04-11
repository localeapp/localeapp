require 'spec_helper'

describe LocaleApp::Updater, ".update(data)" do
  before(:each) do
    @yml_dir = Dir.mktmpdir
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'fixtures', '*.yml')).each { |f| FileUtils.cp f, @yml_dir }
  end

  after(:each) do
    FileUtils.rm_rf @yml_dir
  end

  def do_update(data)
    with_configuration(:translation_data_directory => @yml_dir) do
      LocaleApp::Updater.update(data)
    end
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
    ]})
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
end
