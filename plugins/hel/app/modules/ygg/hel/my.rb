module Ygg
module Hel

module My

  #
  # returns resources assigned to the current person
  #
  def my
    self.ar_resources_relation = ar_model.belonging_to(aaa_context.auth_person).includes(ar_model.interfaces[:rest].eager_loading_hints(
                                                                 view: ar_view))

    ar_retrieve_resources
    # Authorization not necessary as we are returning owned objects

    # Avoid responding with nil-classes when the array is empty
    root_name = ''

    if ar_model
      root_name = ActiveSupport::Inflector.pluralize(
                    ActiveSupport::Inflector.underscore(ar_model.name)).tr('/', '_')
    end

    ar_respond_with(ar_resources, total: ar_resources_count, root: root_name)
  end

  def summary
    self.ar_resources_relation = ar_model.belonging_to(aaa_context.auth_person).includes(ar_model.interfaces[:rest].
                          eager_loading_hints(view: ar_view))

    ar_retrieve_resources
    # Authorization not necessary as we are returning owned objects

    summary = { total: ar_resources_count, states: {}, details: {} }

    ar_resources.each do |service|
      state = service.respond_to?(:replicas_state) ? service.replicas_state : 'UNKNOWN'
      summary[:states][state] ||= 0
      summary[:states][state] += 1
    end

    summary[:details] = summary_details if respond_to?(:summary_details)

    ar_respond_with(summary)
  end

  def find_and_check_agreement(req)
    agreement = Ygg::Shop::Agreement.find(req[:agreement_id])

    if !agreement.belongs_to?(aaa_context.auth_person)
      raise RailsActiveRest::Controller::AuthorizationError.new(
          title: 'You do not have the required role to use this agreement.')
    end

    agreement
  end
end

end
end
