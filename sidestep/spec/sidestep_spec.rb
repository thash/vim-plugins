# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'tmpdir'

PLUGIN = 'sidestep'

describe "#{PLUGIN}.vim" do

  ############### prepare data and Vimrunner ###############

  def make_and_edit(str, filename='data.in')
    # http://stackoverflow.com/questions/8565357/undo-all-changes-since-opening-buffer-in-vim
    # undo all changes then delete buffer
    @vim.normal("u1|u")
    @vim.command("bdelete")
    File.open(filename, "w") do |f|
      f.puts(<<-__EOF__)
#{str}
      __EOF__
    end
    @vim.command("edit #{filename}")
  end

  before :all do
    @vim = Vimrunner.start
    @vim.add_plugin(File.expand_path('../../', __FILE__), "plugin/#{PLUGIN}.vim")
    @sid = @vim.command('scriptnames').split("\n").find{|script|
      script.index("#{PLUGIN}.vim")
    }.scan(/(\d+):/)[0][0].to_i
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
    make_and_edit("hoge")
    @vim.echo("filereadable(expand('data.in'))").should eq "1"
  end

  it 'loads plugin' do
    @vim.echo("exists(\"g:loaded_#{PLUGIN}\")").should eq "1"
  end

  ############### plugin specific specs ###############
  it 'replace when the line has 3 items' do
    make_and_edit("hoge, test, fuga")
    @vim.normal("gg0")
    @vim.command("call <SNR>#{@sid}_Sidestep('r')")
    @vim.echo("getline('.')").should eq "test, hoge, fuga"
  end

  describe 'with (double|single) quote' do
    # [orig] (get*line('.'), 'aa,bbb')
    #   [x]  ('aa, get*line('.'),bbb')
    #   [o]  ('aa,bbb', get*line('.'))
    it 'should detect quote-surrounded arguments' do
      make_and_edit("(getline('.'), 'aa,bbb')")
      @vim.normal("gg03l")
      @vim.command("call <SNR>#{@sid}_Sidestep('r')")
      @vim.echo("getline('.')").should eq "('aa,bbb', getline('.'))"
    end

    # [orig] "ho*ge, test, fuga"
    #   [x]  test, "ho*ge, fuga"
    #   [o]  "test, ho*ge, fuga"
    it 'should work inside a quote' do
      make_and_edit('"hoge, test, fuga"')
      @vim.normal("gg02l")
      @vim.command("call <SNR>#{@sid}_Sidestep('r')")
      @vim.echo("getline('.')").should eq '"test, hoge, fuga"'
    end
  end
end
