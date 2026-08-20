#!/usr/bin/env ruby
# Idempotently adds the Xcode build configurations used by Flutter flavors.
require "xcodeproj"

project_path = File.expand_path("../ios/Runner.xcodeproj", __dir__)
project = Xcodeproj::Project.open(project_path)

def duplicate_configuration(project, configuration_list, source_name, target_name)
  existing = configuration_list.build_configurations.find { |config| config.name == target_name }
  return existing if existing

  source = configuration_list.build_configurations.find { |config| config.name == source_name }
  raise "Missing source configuration #{source_name}" unless source

  config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  config.name = target_name
  config.build_settings = source.build_settings.dup
  config.base_configuration_reference = source.base_configuration_reference
  configuration_list.build_configurations << config
  config
end

environments = {
  "dev" => {
    "bundle_id" => "com.sunnyinnolab.worldMovieTrailer.dev",
    "display_name" => "World Movie Trailer Dev",
    "flutter_target" => "lib/main_dev.dart",
  },
  "prod" => {
    "bundle_id" => "com.sunnyinnolab.worldMovieTrailer",
    "display_name" => "World Movie Trailer",
    "flutter_target" => "lib/main_prod.dart",
  },
}

runner = project.targets.find { |target| target.name == "Runner" }
runner_tests = project.targets.find { |target| target.name == "RunnerTests" }
raise "Runner target not found" unless runner
flutter_group = project.main_group.find_subpath("Flutter", true)

environments.each do |environment, settings|
  {"Debug" => "Debug", "Profile" => "Profile", "Release" => "Release"}.each do |source_name, prefix|
    target_name = "#{prefix}-#{environment}"
    duplicate_configuration(project, project.build_configuration_list, source_name, target_name)
    runner_config = duplicate_configuration(project, runner.build_configuration_list, source_name, target_name)
    runner_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = settings["bundle_id"]
    runner_config.build_settings["APP_DISPLAY_NAME"] = settings["display_name"]
    runner_config.build_settings["FLUTTER_TARGET"] = settings["flutter_target"]
    xcconfig_name = "#{prefix}-#{environment}.xcconfig"
    xcconfig_ref = flutter_group.files.find { |file| file.path == xcconfig_name || file.path == "Flutter/#{xcconfig_name}" }
    xcconfig_ref ||= flutter_group.new_file(xcconfig_name)
    xcconfig_ref.name = xcconfig_name
    xcconfig_ref.path = "Flutter/#{xcconfig_name}"
    runner_config.base_configuration_reference = xcconfig_ref

    next unless runner_tests
    tests_config = duplicate_configuration(project, runner_tests.build_configuration_list, source_name, target_name)
    tests_config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "#{settings["bundle_id"]}.RunnerTests"
  end
end

project.save
puts "Configured iOS dev/prod build configurations."
