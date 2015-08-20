require "minitest/autorun"
require_relative "ls"

class LsTest < Minitest::Test
  def run
    within_test_dir do
      super
    end
  end

  def test_simple_ls
    with_safe_stdout do |ios|
      run_ls
      assert_equal %w(another_dir executable1 file1), ios.string.split(" ")
    end
  end

  def test_ls_of_file
    with_safe_stdout do |ios|
      run_ls("file1")
      assert_equal "file1", ios.string.chomp.strip
    end
  end

  def test_ls_colored
    with_safe_stdout do |ios|
      run_ls(options: ["-G"])
      colored_dir = ListsFile.new(filename: "another_dir").colored
      colored_executable = ListsFile.new(filename: "executable1").colored
      assert_equal [colored_dir, colored_executable, "file1"], ios.string.split(" ")
    end
  end

  def test_ls_oneline
    with_safe_stdout do |ios|
      run_ls(options: ["-1"])
      assert_equal %w(another_dir executable1 file1), ios.string.split("\n")
    end
  end

  private

  def within_test_dir
    Dir.chdir("test_dir") do
      yield
    end
  end

  def with_safe_stdout
    ios = StringIO.new
    $stdout = ios
    yield ios
  end
end
