require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/report'
require 'reek'

module CodeChecks

  include Reek

  def check(desc, src, expected, pending_str = nil)
    it(desc) do
      pending(pending_str) unless pending_str.nil?
      rpt = Analyser.new(src).analyse
      rpt.length.should == expected.length
      (0...rpt.length).each do |smell|
        expected[smell].each { |patt| rpt[smell].report.should match(patt) }
      end
    end
  end
end