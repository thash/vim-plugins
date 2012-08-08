# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.require

PLUGIN = 'sidestep'

describe "#{PLUGIN}.vim" do

  ############### prepare data and Vimrunner ###############

  def prepare_data(filename='data.in')
    system "cat << __EOF__ > #{filename}
hoge, test, fuga
def method c, b, a
(test, hoge, fuga)
def mmm(test, fuga, hoge)
def mmm(test, fuga, hoge) tuhng
def mmm( test, fuga, hoge )
__EOF__"
  end

  def clean_data(filename='data.in')
    system "rm #{filename}"
  end

  before :all do
    @vim = Vimrunner.start
    @vim.add_plugin(File.expand_path('../../', __FILE__), "plugin/#{PLUGIN}.vim")
    prepare_data
  end

  after :all do
    @vim.kill
    clean_data
  end

  it "Vimrunner runs correctly" do
    @vim.class.should eq Vimrunner::Client
  end

  it 'loads plugin' do
    @vim.echo("exists(\"g:loaded_#{PLUGIN}\")").should eq "1"
  end

  ############### plugin specific specs ###############

  it 'replace when the line has 3 items' do
    # @vim.command "pwd"
  end

end


