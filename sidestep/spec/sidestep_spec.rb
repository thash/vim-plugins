# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'tmpdir'

PLUGIN = 'sidestep'

describe "#{PLUGIN}.vim" do

  ############### prepare data and Vimrunner ###############

  def mkfilewith(str, filename='data.in')
    File.open(filename, "w") do |f|
      f.puts(<<-__EOF__)
#{str}
      __EOF__
    end
  end

  before :all do
    @vim = Vimrunner.start
    @vim.add_plugin(File.expand_path('../../', __FILE__), "plugin/#{PLUGIN}.vim")
  end

  after :all do
    @vim.kill
  end

  # make tmpdir with Dir.mktmpdir for vim test.
  around do |example|
    # tmpdir is like /private/var/folders/vl/kz6rxxx000gn/T/d20120809-7454..
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        @vim.command "cd #{dir}"
        example.run
      end
    end
  end

  it "Vimrunner runs correctly" do
    @vim.class.should eq Vimrunner::Client
  end

  it 'around filter + tmpdir works correctly' do
    mkfilewith("hoge", "test.in")
    @vim.echo("filereadable(expand('test.in'))").should eq "1"
  end

  it 'loads plugin' do
    @vim.echo("exists(\"g:loaded_#{PLUGIN}\")").should eq "1"
  end

  ############### plugin specific specs ###############
  it 'replace when the line has 3 items' do
    mkfilewith("hoge, test, fuga")
  end

end


