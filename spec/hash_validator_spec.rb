require 'spec_helper'
require 'hash_validator'

describe HashValidator do
  context 'required/optional keys' do
    ok = {foo: 'bar', bar: 'foo'}
    also_ok = {foo: 'bar'}
    bad = {bar: 'foo'}

    v = HashValidator.new
    v.required(:foo)
    v.optional(:bar)

    v.valid?(ok).should == true
    v.valid?(bad).should == false

    v.valid?(also_ok).should == true
  end

  context 'key type specification' do
    specify 'key type defaults to string' do
      ok = {foo: 'bar'}
      bad = {foo: 1}

      v = HashValidator.new
      v.required(:foo)

      v.valid?(ok).should == true
      v.valid?(bad).should == false
    end

    specify 'must be ruby classes' do
      v = HashValidator.new
      v.required(:foo) { type Fixnum }
      v.required(:bar) { type Array }

      ok = {foo: 3, bar: [1, 2, 3]}
      bad = {foo: 3, bar: 4}

      v.valid?(ok).should == true
      v.valid?(bad).should == false

      expect {
        v.required(:baz) { type :invalid }
      }.to raise_exception(ArgumentError)
    end

    specify 'mixed type arrays are allowed' do
      v = HashValidator.new
      v.required(:foo) { type Array }

      v.valid?({
        foo: [1, 2, 'three']
      }).should == true
    end
  end

  context 'arrays of allowed values may be specified' do
    specify 'for strings and fixnums' do
      v = HashValidator.new
      v.required :foo do
        type Fixnum
        allowed_values [1, 2, 3]
      end

      v.required :bar do
        allowed_values %w{one two three}
      end

      ok = {foo: 2, bar: 'two'}
      bad = {foo: 4, bar: 'four'}

      v.valid?(ok).should == true
      v.valid?(bad).should == false
    end

    specify 'for arrays' do
      v = HashValidator.new
      v.required :foo do
        type Array
        allowed_values [1, 2, 3]
      end

      v.optional :bar do
        type Array
        allowed_values [1, 2, 'three']
      end

      v.valid?({foo: [2, 3, 4]}).should == false
      v.valid?({foo: [2, 3]}).should == true
      v.valid?({foo: [2], bar: [1, 'three']}).should == true
      v.valid?({foo: [2], bar: [4]}).should == false
    end
  end

  context 'arrays of forbidden values may be specified' do
    specify 'for strings and fixnums' do
      v = HashValidator.new
      v.required :foo do
        type Fixnum
        forbidden_values [1, 2, 3]
      end

      v.required :bar do
        forbidden_values %w{one two three}
      end

      bad = {foo: 2, bar: 'two'}
      ok = {foo: 4, bar: 'four'}

      v.valid?(ok).should == true
      v.valid?(bad).should == false
    end

    specify 'for arrays' do
      v = HashValidator.new
      v.required :foo do
        type Array
        forbidden_values [1, 2, 3]
      end

      v.valid?({foo: [2, 3, 4]}).should == false
      v.valid?({foo: [2, 3]}).should == false
      v.valid?({foo: [0, 4]}).should == true
    end
  end

  context 'nested hash validation' do
    specify 'works as expected' do
      v = HashValidator.new
      v.required(:foo) do
        type Hash
        required(:bar) { type Fixnum }
        required :baz
      end

      v.valid?({
        foo: {
          bar: 4,
          baz: 'omg'
        }
      }).should == true

      v.valid?({
        foo: {
          bar: 5,
          baz: 7
        }
      }).should == false
    end

    specify 'supports multiple levels of nesting' do
      v = HashValidator.new

      v.required(:hsh1) do
        type Hash
        required(:hsh2) do
          type Hash
          required(:hsh3) do
            type Hash
            required :foo
          end
        end
      end

      v.valid?({
        hsh1: {
          hsh2: {
            hsh3: {
              foo: 'hello'
            }
          }
        }
      }).should == true
    end

    specify 'supports multiple levels of nesting among other keys' do
      v = HashValidator.new

      v.required(:hsh1) do
        type Hash
        required :str
        required(:int) { type Fixnum }

        required(:hsh2) do
          type Hash
          required(:ary) do
            type Array
            allowed_values [1, 2, 3, 'four']
          end
        end
      end

      v.valid?({
        hsh1: {
          str: 'hello',
          int: 8,
          hsh2: {
            ary: [1, 'fo']
          }
        }
      }).should == false

      v.valid?({
        hsh1: {
          str: 'hello',
          int: 5,
          hsh2: {
            ary: [1, 'four']
          }
        }
      }).should == true
    end
  end
end