FactoryGirl.define do
  factory :business do
    factory :business_with_check_ins do
      transient do
        ci_count 3
      end
      after(:create) do |business, eval|
        create_list(:check_in, eval.ci_count, business: business)
      end
    end
  end
end
