require "application_system_test_case"

class PatientsTest < ApplicationSystemTestCase
  setup do
    @patient = patients(:one)
  end

  test "visiting the index" do
    visit patients_url
    assert_selector "h1", text: "Patients"
  end

  test "creating a Patient" do
    visit patients_url
    click_on "New Patient"

    fill_in "Admin", with: @patient.admin_id
    fill_in "Email", with: @patient.email
    fill_in "First name", with: @patient.first_name
    fill_in "Last name", with: @patient.last_name
    fill_in "Middle initial", with: @patient.middle_initial
    fill_in "Phone", with: @patient.phone
    click_on "Create Patient"

    assert_text "Patient was successfully created"
    click_on "Back"
  end

  test "updating a Patient" do
    visit patients_url
    click_on "Edit", match: :first

    fill_in "Admin", with: @patient.admin_id
    fill_in "Email", with: @patient.email
    fill_in "First name", with: @patient.first_name
    fill_in "Last name", with: @patient.last_name
    fill_in "Middle initial", with: @patient.middle_initial
    fill_in "Phone", with: @patient.phone
    click_on "Update Patient"

    assert_text "Patient was successfully updated"
    click_on "Back"
  end

  test "destroying a Patient" do
    visit patients_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Patient was successfully destroyed"
  end
end
