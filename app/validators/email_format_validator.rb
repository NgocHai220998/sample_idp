# frozen_string_literal: true

class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    return if value.match?(URI::MailTo::EMAIL_REGEXP)

    record.errors.add(attribute, 'is not an email, please enter a valid email address!')
  end
end
