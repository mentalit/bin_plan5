require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:one)
  end

  test "visiting the index" do
    visit articles_url
    assert_selector "h1", text: "Articles"
  end

  test "should create article" do
    visit articles_url
    click_on "New article"

    fill_in "Artname unicode", with: @article.ARTNAME_UNICODE
    fill_in "Artno", with: @article.ARTNO
    fill_in "Baseonhand", with: @article.BASEONHAND
    fill_in "Cp height", with: @article.CP_HEIGHT
    fill_in "Cp length", with: @article.CP_LENGTH
    fill_in "Cp width", with: @article.CP_WIDTH
    fill_in "Dtfp", with: @article.DTFP
    fill_in "Dtfp plus", with: @article.DTFP_PLUS
    fill_in "Eds", with: @article.EDS
    fill_in "Hfb", with: @article.HFB
    fill_in "Mpq", with: @article.MPQ
    fill_in "Pa", with: @article.PA
    fill_in "Palq", with: @article.PALQ
    fill_in "Rssq", with: @article.RSSQ
    fill_in "Salesmethod", with: @article.SALESMETHOD
    fill_in "Slid h", with: @article.SLID_H
    fill_in "Ssd", with: @article.SSD
    fill_in "Ul height gross", with: @article.UL_HEIGHT_GROSS
    fill_in "Ul length gross", with: @article.UL_LENGTH_GROSS
    fill_in "Ul width gross", with: @article.UL_WIDTH_GROSS
    fill_in "Weight g", with: @article.WEIGHT_G
    fill_in "New assq", with: @article.new_assq
    fill_in "New slid", with: @article.new_slid
    check "Planned" if @article.planned
    fill_in "Store", with: @article.store_id
    click_on "Create Article"

    assert_text "Article was successfully created"
    click_on "Back"
  end

  test "should update Article" do
    visit article_url(@article)
    click_on "Edit this article", match: :first

    fill_in "Artname unicode", with: @article.ARTNAME_UNICODE
    fill_in "Artno", with: @article.ARTNO
    fill_in "Baseonhand", with: @article.BASEONHAND
    fill_in "Cp height", with: @article.CP_HEIGHT
    fill_in "Cp length", with: @article.CP_LENGTH
    fill_in "Cp width", with: @article.CP_WIDTH
    fill_in "Dtfp", with: @article.DTFP
    fill_in "Dtfp plus", with: @article.DTFP_PLUS
    fill_in "Eds", with: @article.EDS
    fill_in "Hfb", with: @article.HFB
    fill_in "Mpq", with: @article.MPQ
    fill_in "Pa", with: @article.PA
    fill_in "Palq", with: @article.PALQ
    fill_in "Rssq", with: @article.RSSQ
    fill_in "Salesmethod", with: @article.SALESMETHOD
    fill_in "Slid h", with: @article.SLID_H
    fill_in "Ssd", with: @article.SSD
    fill_in "Ul height gross", with: @article.UL_HEIGHT_GROSS
    fill_in "Ul length gross", with: @article.UL_LENGTH_GROSS
    fill_in "Ul width gross", with: @article.UL_WIDTH_GROSS
    fill_in "Weight g", with: @article.WEIGHT_G
    fill_in "New assq", with: @article.new_assq
    fill_in "New slid", with: @article.new_slid
    check "Planned" if @article.planned
    fill_in "Store", with: @article.store_id
    click_on "Update Article"

    assert_text "Article was successfully updated"
    click_on "Back"
  end

  test "should destroy Article" do
    visit article_url(@article)
    click_on "Destroy this article", match: :first

    assert_text "Article was successfully destroyed"
  end
end
