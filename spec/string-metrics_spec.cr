require "./spec_helper"

describe "StringMetrics" do
  it "levenshtein both empty" do
    StringMetrics.levenshtein("", "").should eq(0)
  end

  it "levenshtein one empty" do
    StringMetrics.levenshtein("", "hi").should eq(2)
  end

  it "levenshtein one missing" do
    StringMetrics.levenshtein("h", "hi").should eq(1)
  end

  it "levenshtein one sub" do
    StringMetrics.levenshtein("ha", "hi").should eq(1)
  end

  it "levenshtein one deletion" do
    StringMetrics.levenshtein("hai", "hi").should eq(1)
  end

  it "levenshtein multiple insertions" do
    StringMetrics.levenshtein("char", "charity").should eq(3)
  end

  it "levenshtein multiple insertions and one substitution" do
    StringMetrics.levenshtein("char", "sharity").should eq(4)
  end

  it "levenshtein with many operations" do
    StringMetrics.levenshtein("example", "samples").should eq(3)
    StringMetrics.levenshtein("sturgeon", "urgently").should eq(6)
    StringMetrics.levenshtein("levenshtein", "frankenstein").should eq(6)
    StringMetrics.levenshtein("distance", "difference").should eq(5)
  end

  it "hamming with differing length strings" do
    StringMetrics.hamming("hi", "ha").should eq(1)
  end

  it "hamming with empty strings" do
    StringMetrics.hamming("", "").should eq(0)
  end

  it "hamming with differing length strings" do
    expect_raises ArgumentError, do
      StringMetrics.hamming("", "check")
    end
  end

  it "damerau levenshtein" do
    StringMetrics.damerau_levenshtein("char", "hcra").should eq(2)
  end

  it "empty strings damerau" do
    StringMetrics.damerau_levenshtein("", "").should eq(0)
  end
end
