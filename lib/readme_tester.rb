require 'deject'
require 'readme_tester/version'
require 'readme_tester/interpreter'

def ReadmeTester(argv)
  ReadmeTester.new(argv).execute
end

class ReadmeTester
  Deject self, :interaction
  dependency(:interpreter_class) { Interpreter }
  dependency(:file_class)        { File }

  def initialize(argv)
    self.argv = argv
  end

  def execute
    missing_input_file || invalid_filename || nonexistent_file || execute!
  end

  def interpreter
    @interpreter ||= interpreter_class.new file_body
  end

private

  def missing_input_file
    return if filename
    interaction.declare_failure 'Please provide an input file'
    1
  end

  def invalid_filename
    return if filename =~ suffix_regex
    interaction.declare_failure "#{filename.inspect} does not end in .testable_readme"
    1
  end

  def nonexistent_file
    return if file_class.exist? filename
    interaction.declare_failure "#{File.expand_path(filename).inspect} does not exist."
    1
  end

  def execute!
    return 1 unless interpreter.tests_pass?
    file_class.write output_filename_for(filename), interpreter.result
    0
  end

  def filename
    argv.first
  end

  def file_body
    file_class.read filename
  end

  def output_filename_for(filename)
    filename.sub suffix_regex, ''
  end

  def suffix_regex
    /\.testable_readme$/
  end

  attr_accessor :argv
end
