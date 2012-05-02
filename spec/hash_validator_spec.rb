require 'spec_helper'
require 'hash_validator'

describe HashValidator do
  context 'required/optional keys' do
    specify 'work as expected' do
      ok = {foo: 'bar', bar: 'foo'}
      also_ok = {foo: 'bar'}
      bad = {bar: 'foo'}
      extra = ok.merge(extra: 'bad')

      v = HashValidator.new
      v.required(:foo)
      v.optional(:bar)

      v.valid?(ok).should == true
      v.valid?(bad).should == false

      v.valid?(also_ok).should == true

      v.valid?(extra).should == false
    end
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

      v = HashValidator.new do
        required :ary do
          type Array
          allowed_values [3, 5, 7]
        end
      end

      v.valid?({
        ary: [2, 4]
      }).should == false
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

  specify '.new instance_execs a block, if given' do
    v = HashValidator.new do
      required :hsh1 do
        type Hash
        required :str
      end

      required(:ary) { type Array }
    end

    v.valid?({
      hsh1: {
        str: 'hello'
      },
      ary: [1, 2, 3]
    }).should == true
  end

  context 'allows re-opening of keys for redefinition' do
    specify 'for a simple type change' do
      v = HashValidator.new do
        required(:foo)
      end

      v.valid?({foo: 'hello'}).should == true

      v.required(:foo) do
        type Fixnum
      end

      v.valid?({foo: 'hello'}).should == false
      v.valid?({foo: 4}).should == true
    end

    specify 'for new allowed_values' do
      v = HashValidator.new do
        required(:foo) do
          allowed_values ['two', 'four', 'six']
        end
      end

      v.valid?({foo: 'two'}).should == true

      v.required(:foo) do
        allowed_values ['one', 'three', 'five']
      end

      v.valid?({foo: 'two'}).should == false
      v.valid?({foo: 'three'}).should == true
    end
  end

  context 'cloning' do
    before(:each) do
      @original = HashValidator.new do
        required(:foo)
      end 
    end

    specify 'dupes the data in @template' do
      orig_template = @original.instance_variable_get(:@template)

      cloned = @original.clone

      @original.instance_variable_get(:@template).object_id.should == orig_template.object_id
      @original.instance_variable_get(:@template).object_id.should_not == cloned.instance_variable_get(:@template).object_id
      @original.instance_variable_get(:@template).should == cloned.instance_variable_get(:@template)

      cloned.required(:foo) { type Fixnum }

      @original.instance_variable_get(:@template).should_not == cloned.instance_variable_get(:@template)
      @original.instance_variable_get(:@template)[:keys][:foo][:opts][:type].should == String
      cloned.instance_variable_get(:@template)[:keys][:foo][:opts][:type].should == Fixnum
    end

    specify 'validation works as expected' do
      cloned = @original.clone
      cloned.required(:foo) { type Fixnum }

      @original.valid?({foo: 'hello'}).should == true
      @original.valid?({foo: 1}).should == false
      cloned.valid?({foo: 'hello'}).should == false
      cloned.valid?({foo: 1}).should == true
    end
  end
end