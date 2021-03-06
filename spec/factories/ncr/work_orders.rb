FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    rwa_number "R1234567"
    org_code Ncr::ORG_CODES[0]
    project_title "NCR Name"
    association :proposal, flow: 'linear'

    trait :with_approvers do
      association :proposal, :with_approvers, flow: 'linear'
    end
  end
end
