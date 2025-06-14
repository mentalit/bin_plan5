require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { ARTNAME_UNICODE: @article.ARTNAME_UNICODE, ARTNO: @article.ARTNO, BASEONHAND: @article.BASEONHAND, CP_HEIGHT: @article.CP_HEIGHT, CP_LENGTH: @article.CP_LENGTH, CP_WIDTH: @article.CP_WIDTH, DTFP: @article.DTFP, DTFP_PLUS: @article.DTFP_PLUS, EDS: @article.EDS, HFB: @article.HFB, MPQ: @article.MPQ, PA: @article.PA, PALQ: @article.PALQ, RSSQ: @article.RSSQ, SALESMETHOD: @article.SALESMETHOD, SLID_H: @article.SLID_H, SSD: @article.SSD, UL_HEIGHT_GROSS: @article.UL_HEIGHT_GROSS, UL_LENGTH_GROSS: @article.UL_LENGTH_GROSS, UL_WIDTH_GROSS: @article.UL_WIDTH_GROSS, WEIGHT_G: @article.WEIGHT_G, new_assq: @article.new_assq, new_slid: @article.new_slid, planned: @article.planned, store_id: @article.store_id } }
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: { article: { ARTNAME_UNICODE: @article.ARTNAME_UNICODE, ARTNO: @article.ARTNO, BASEONHAND: @article.BASEONHAND, CP_HEIGHT: @article.CP_HEIGHT, CP_LENGTH: @article.CP_LENGTH, CP_WIDTH: @article.CP_WIDTH, DTFP: @article.DTFP, DTFP_PLUS: @article.DTFP_PLUS, EDS: @article.EDS, HFB: @article.HFB, MPQ: @article.MPQ, PA: @article.PA, PALQ: @article.PALQ, RSSQ: @article.RSSQ, SALESMETHOD: @article.SALESMETHOD, SLID_H: @article.SLID_H, SSD: @article.SSD, UL_HEIGHT_GROSS: @article.UL_HEIGHT_GROSS, UL_LENGTH_GROSS: @article.UL_LENGTH_GROSS, UL_WIDTH_GROSS: @article.UL_WIDTH_GROSS, WEIGHT_G: @article.WEIGHT_G, new_assq: @article.new_assq, new_slid: @article.new_slid, planned: @article.planned, store_id: @article.store_id } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end
end
