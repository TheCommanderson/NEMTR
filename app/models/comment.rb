# frozen_string_literal: true

class Comment
  include Mongoid::Document

  # The user ID of the user that made the comment
  field :author, type: String
  field :text, type: String

  # Comments can belong to a patient in the case that a driver/volunteer/admin
  # is making a comment about the patient.  Comments can belong to appointments
  # when they are reports.
  belongs_to :patient, optional: true
  belongs_to :appointment, optional: true
end
