require 'rails_helper'

RSpec.describe TeaSub, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  it { should belong_to :tea}
  it { should belong_to :subscription}
end
