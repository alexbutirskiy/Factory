## Factory project solution for RubyGarage Courses
[![Build Status](https://travis-ci.org/alexbutirskiy/factory.svg?branch=master)](https://travis-ci.org/alexbutirskiy/factory)
[![Test Coverage](https://codeclimate.com/github/alexbutirskiy/factory/badges/coverage.svg)](https://codeclimate.com/github/alexbutirskiy/factory/coverage)

Factory class provides a way to store in the same objects other different predefined objects also as methods.
Usage:
```ruby
  require 'factory'
  Customer = Factory.new(:name, :address, :zip)
  => Customer

  joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)
  => #<struct Customer name="Joe Smith", address="123 Maple, Anytown NC",
  zip=12345>

  joe.name
  joe["name"]
  joe[:name]
  joe[0]
  => "Joe Smith"
  ```