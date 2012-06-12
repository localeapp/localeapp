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
      if Psych::VERSION == '1.0.0'
        File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en:
  foo:
    monkey: hello
    night: the night
  space: !!null 
  blank: ''
  tilde: !!null 
  scalar1: !!null 
  scalar2: !!null 
EN
      else
        File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en:
  foo:
    monkey: hello
    night: the night
  space: 
  blank: ''
  tilde: 
  scalar1: 
  scalar2: 
EN
      end
    else
      File.read(File.join(@yml_dir, 'en.yml')).should == <<-EN
en: 
  blank: ""
  foo: 
    monkey: hello
    night: "the night"
  scalar1: ~
  scalar2: ~
  space: ~
  tilde: ~
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

  if defined? Psych
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
end
