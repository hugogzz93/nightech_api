module TestHelpers
	RSpec::Matchers.define :have_same_organization_as do |expected|
	  match do |actual|
	    actual.organization == expected.organization
	  end
	end
end