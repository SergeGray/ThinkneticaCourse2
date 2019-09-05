require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create(name: "Sergey", email: 'sergey@example.com') }
  let!(:category) { Category.create(title: "Web") }
  let!(:tests) do
    Test.create!(
      [
        { title: "HTML", category: category, level: 1, author: user },
        { title: "Javascript", category: category, level: 2, author: user },
        { title: "CSS", category: category, level: 1, author: user }
      ]
    )
  end
  let!(:attempts) do
    Attempt.create!(
      [
        { user: user, test: tests.first },
        { user: user, test: tests.second },
        { user: user, test: tests.third }
      ]
    )
  end

  describe "dependent" do
    it "nullifies all created test foreign keys" do
      user.destroy
      tests.each do |test|
        test.reload
        expect(test.author).to be nil
      end
    end

    it "destroys all associated attempts" do
      user.destroy!
      attempts.each do |attempt|
        expect(Attempt.exists?(attempt.id)).to be false
      end
    end
  end

  describe "validates" do
    describe "name" do
      let(:valid_attributes) { { name: "Bob", email: "bob@bob.bob" } }
      let(:invalid_attributes) { { name: "", email: "invalid@fake.person" } }

      it "allows to create a user with a valid name" do
        new_user = User.new(valid_attributes)
        expect(new_user.valid?).to be true
      end

      it "disllows to create a user with an invalid name" do
        new_user = User.new(invalid_attributes)
        new_user.valid?
        expect(new_user.errors[:name]).to eq([BLANK_ERROR])
      end
    end

    describe "email" do
      let(:valid_attributes) { { name: "Bob", email: "bob@bob.bob" } }
      let(:invalid_attributes) { { name: "Bill", email: "" } }

      it "allows to create a user with a valid email" do
        new_user = User.new(valid_attributes)
        expect(new_user.valid?).to be true
      end

      it "disllows to create a user with an invalid email" do
        new_user = User.new(invalid_attributes)
        new_user.valid?
        expect(new_user.errors[:email]).to eq([BLANK_ERROR])
      end

      it "disllows to create a user with an existing email" do
        User.create!(valid_attributes)
        new_user = User.new(valid_attributes)
        new_user.valid?
        expect(new_user.errors[:email]).to eq([TAKEN_ERROR])
      end
    end
  end

  describe "#started_by_level" do
    it "returns all started tests with specified level" do
      expect(user.started_by_level(1)).to contain_exactly(
        tests.first, tests.third
      )
    end
  end
end
