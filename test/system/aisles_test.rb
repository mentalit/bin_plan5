require "application_system_test_case"

class AislesTest < ApplicationSystemTestCase
  setup do
    @aisle = aisles(:one)
  end

  test "visiting the index" do
    visit aisles_url
    assert_selector "h1", text: "Aisles"
  end

  test "should create aisle" do
    visit aisles_url
    click_on "New aisle"

    fill_in "Aisledepth", with: @aisle.aisledepth
    fill_in "Aisleend", with: @aisle.aisleend
    fill_in "Aisleheight", with: @aisle.aisleheight
    fill_in "Aislenum", with: @aisle.aislenum
    fill_in "Aislestart", with: @aisle.aislestart
    fill_in "Store", with: @aisle.store_id
    click_on "Create Aisle"

    assert_text "Aisle was successfully created"
    click_on "Back"
  end

  test "should update Aisle" do
    visit aisle_url(@aisle)
    click_on "Edit this aisle", match: :first

    fill_in "Aisledepth", with: @aisle.aisledepth
    fill_in "Aisleend", with: @aisle.aisleend
    fill_in "Aisleheight", with: @aisle.aisleheight
    fill_in "Aislenum", with: @aisle.aislenum
    fill_in "Aislestart", with: @aisle.aislestart
    fill_in "Store", with: @aisle.store_id
    click_on "Update Aisle"

    assert_text "Aisle was successfully updated"
    click_on "Back"
  end

  test "should destroy Aisle" do
    visit aisle_url(@aisle)
    click_on "Destroy this aisle", match: :first

    assert_text "Aisle was successfully destroyed"
  end
end
