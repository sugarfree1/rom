require 'spec_helper'
require 'rom/memory'

RSpec.describe 'Setting up ROM with multiple environments' do
  let(:configuration) do
    {
      one: ROM::Configuration.new(:memory),
      two: ROM::Configuration.new(:memory)
    }
  end

  let(:container) do
    {
      one: ROM.container(configuration[:one]),
      two: ROM.container(configuration[:two]),
    }
  end

  context 'without :auto_registration plugin' do
    before do
      module Test
        class Users < ROM::Relation[:memory]
          dataset :users
        end

        class CreateUser < ROM::Commands::Create[:memory]
          register_as :create
          relation :users
          result :one
        end

        class UserMapper < ROM::Mapper
          relation :users
          register_as :entity
        end
      end
    end

    it 'registers items independently of other environments' do
      configuration[:one].register_relation(Test::Users)
      configuration[:one].register_command(Test::CreateUser)
      configuration[:one].register_mapper(Test::UserMapper)

      expect(container[:one].relations[:users]).to be_kind_of Test::Users
      expect(container[:one].commands[:users].create).to be_kind_of Test::CreateUser
      expect(container[:one].mappers[:users].entity).to be_kind_of Test::UserMapper

      expect { container[:two].relations[:users] }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
      expect { container[:two].commands[:users].create }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
      expect { container[:two].commands[:users].create }.to raise_error(
        ROM::Registry::ElementNotFoundError
      )
    end

    it 'allows use of the same identifiers in different environments' do
      configuration[:one].register_relation(Test::Users)
      configuration[:one].register_command(Test::CreateUser)
      configuration[:one].register_mapper(Test::UserMapper)

      expect { configuration[:two].register_relation(Test::Users) }.to_not raise_error
      expect { configuration[:two].register_command(Test::CreateUser) }.to_not raise_error
      expect { configuration[:two].register_mapper(Test::UserMapper) }.to_not raise_error
    end
  end
end
