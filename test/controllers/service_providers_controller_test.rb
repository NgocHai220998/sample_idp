# frozen_string_literal: true

require 'test_helper'

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get service_providers_index_url
    assert_response :success
  end

  test 'should get show' do
    get service_providers_show_url
    assert_response :success
  end

  test 'should get new' do
    get service_providers_new_url
    assert_response :success
  end

  test 'should get edit' do
    get service_providers_edit_url
    assert_response :success
  end

  test 'should get create' do
    get service_providers_create_url
    assert_response :success
  end

  test 'should get update' do
    get service_providers_update_url
    assert_response :success
  end

  test 'should get destroy' do
    get service_providers_destroy_url
    assert_response :success
  end
end
