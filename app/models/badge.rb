# == Schema Information
#
# Table name: badges
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  first_name :string(255)
#  last_name  :string(255)
#  company    :string(255)
#  country    :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "csv"

class Badge < ActiveRecord::Base
  fields = %w(company email first_name last_name country title).map(&:to_sym)

  # FIXME rails41
  attr_accessible *fields

  fields.each do |field|
    validates field, :presence => { :message => "est un champ obligatoire" }
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Timestamp", "SOCIETE EXPOSANTE QUI A FAIT LA DEMANDE*", "Votre SOCIETE*", "CIVILITE*", "PRENOM*", "NOM*", "PAYS*", "EMAIL*"]
      all.each do |b|
        csv << [b.created_at, "LinuxFr", b.company, b.title, b.first_name, b.last_name, b.country, b.email]
      end
    end
  end
end
