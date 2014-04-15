require 'spec_helper'

# Integration Spec: Cart approval
# - Setup: Approval group with 3 approvers (no cart_id which will be populated)
# Make request to /approval_reply_received endpoint (3 times)
# Check the status on each of the approvers
# Email: Check the progress messages on each of them
# Check status on the cart

describe 'Approving a cart with multiple approvers' do

  let(:params) {
      '{
      "cartNumber": "246810",
      "category": "approvalreply",
      "attention": "",
      "fromAddress": "approver1@some-dot-gov.gov",
      "gsaUserName": "",
      "gsaUsername": null,
      "date": "Sun, 13 Apr 2014 18:06:15 -0400",
      "approve": "APPROVE",
      "disapprove": null
      }'
    }

  let(:approver) { FactoryGirl.create(:approver) }

  before do
    approval_group = ApprovalGroup.create(name: "A Testworthy Approval Group")
    approval_group.approvers << Approver.create(email_address: "approver1@some-dot-gov.gov")
    approval_group.approvers << Approver.create(email_address: "approver2@some-dot-gov.gov")
    approval_group.approvers << Approver.create(email_address: "approver3@some-dot-gov.gov")

    cart = Cart.new(
                    name: 'My Wonderfully Awesome Communicart',
                    status: 'pending',
                    external_id: '10203040'
                    )
    cart.approval_group = approval_group
    cart.save
  end

  it 'updates the records as expected' do
    Cart.count.should == 1
    Approver.count.should == 3
    expect(Cart.first.approval_group.approvers.count).to eq 3
    expect(Cart.first.approval_group.approvers.where(status: 'approved').count).to eq 0

    #--- LEFT OF HERE: make the request



  end
end