module Ygg
module Hel

module CustomerWizardActions

  def customer_common_wizard_create(respond_with_key)
    agreement = find_and_check_agreement(json_request)
    resource = customer_prepare_resource(agreement, json_request)

    if resource.valid?
      if !request.headers['X-Validate-Only']
        hel_transaction('Created via Customer Wizard') do |transaction|
          resource.save!
        end
        resource.reload
      end

      ar_respond_with({ respond_with_key: resource })
    else
      if !resource.valid?
        raise RailsActiveRest::Controller::UnprocessableEntity.new(
          title: 'The form is invalid',
          title_sym: 'the_form_is_invalid',
          data: { errors: resource.errors.details.to_hash },
          retry_possible: false)
      end
    end
  end
end

end
end
