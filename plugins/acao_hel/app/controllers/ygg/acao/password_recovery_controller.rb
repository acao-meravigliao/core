#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class PasswordRecoveryController < Ygg::Hel::BaseController
  layout false

  class AccountNotFound < RailsActiveRest::Controller::UnprocessableEntity ; end
  class CredentialNotFound < RailsActiveRest::Controller::UnprocessableEntity ; end
  class ContactNotFound < RailsActiveRest::Controller::UnprocessableEntity ; end

  def recover

    member = Ygg::Acao::Member.find_by(code: json_request[:code])
    raise AccountNotFound if !member

    person = member.person

    credential = person.credentials.where('fqda LIKE \'%@cp.acao.it\'').first
    raise CredentialNotFound if !credential

    contact = person.contacts.where(type: 'email').first
    raise ContactNotFound if !contact

    Ygg::Ml::Msg.notify(destinations: person, template: 'PASSWORD_RECOVERY', template_context: {
      first_name: person.first_name,
      password: credential.password,
    }, objects: person)

    respond_to do |format|
      format.json { render json: { success: true } }
    end
  end
end

end
end
