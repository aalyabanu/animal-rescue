require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_one(:staff_account).dependent(:destroy) }
    it { should have_one(:adopter_account).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
  end

  describe ".organization_staff" do
    it "returns all users with staff accounts" do
      user = create(:user, :verified_staff)
      organization = user.staff_account.organization
      expect(User.organization_staff(organization.id)).to include(user)

      user.staff_account.destroy
      expect(User.organization_staff(organization.id)).not_to include(user)
    end
  end
end
