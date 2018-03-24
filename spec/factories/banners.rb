# encoding: UTF-8
#
# == Schema Information
#
# Table name: banners
#
#  id      :integer          not null, primary key
#  title   :string(255)
#  content :text(16777215)
#  active  :boolean          default(TRUE)
#

FactoryGirl.define do
  factory :banner do
    title   "RMLL 2010"
    content '<a href="http://2010.rmll.info/">Rencontres Mondiales du Logiciel Libre 2010 à Bordeaux</a>'
  end
end
