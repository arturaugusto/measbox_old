require 'test_helper'

class ReportTemplatesControllerTest < ActionController::TestCase
  setup do
    @report_template = report_templates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_template" do
    assert_difference('ReportTemplate.count') do
      post :create, report_template: { laboratory_id: @report_template.laboratory_id, name: @report_template.name, value: @report_template.value }
    end

    assert_redirected_to report_template_path(assigns(:report_template))
  end

  test "should show report_template" do
    get :show, id: @report_template
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_template
    assert_response :success
  end

  test "should update report_template" do
    patch :update, id: @report_template, report_template: { laboratory_id: @report_template.laboratory_id, name: @report_template.name, value: @report_template.value }
    assert_redirected_to report_template_path(assigns(:report_template))
  end

  test "should destroy report_template" do
    assert_difference('ReportTemplate.count', -1) do
      delete :destroy, id: @report_template
    end

    assert_redirected_to report_templates_path
  end
end
