#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

BuildrPlus::Roles.role(:sync_model, :requires => [:sync]) do

  if BuildrPlus::FeatureManager.activated?(:domgen)
    generators = [:sync_master_ejb_impl, :ejb_services, :sync_remote_sync_service]
    generators += project.additional_domgen_generators
    Domgen::Build.define_generate_task(generators,
                                       :buildr_project => project,
                                       :keep_file_patterns => project.all_keep_file_patterns,
                                       :keep_file_names => project.keep_file_names,
                                       :pre_generate_task => 'domgen:pre_generate',
                                       :clean_generated_files => BuildrPlus::Generate.clean_generated_files?) do |t|
      BuildrPlus::Generate.generated_directories << t.target_dir
      t.mark_as_generated_in_ide = !project.inline_generated_source?
      t.filter = Proc.new do |artifact_type, artifact|
        Domgen::Filters.is_in_data_modules?([:Master], artifact_type, artifact) &&
          (artifact_type != :service || artifact.name == :SyncTempPopulationService)
      end
    end
  end

  project.publish = true

  compile.using :javac
  compile.with BuildrPlus::Libs.ee_provided

  compile.with artifacts([BuildrPlus::Appconfig.appconfig_server, BuildrPlus::Libs.field_filter])
  compile.with artifacts([BuildrPlus::Syncrecord.syncrecord_server, BuildrPlus::Syncrecord.syncrecord_rest_client])
  compile.with Buildr.artifacts([BuildrPlus::Libs.keycloak_authfilter]) if BuildrPlus::FeatureManager.activated?(:keycloak)

  BuildrPlus::Roles.merge_projects_with_role(project.compile, :model)

  package(:jar)
  package(:sources)

  iml.add_jpa_facet if BuildrPlus::FeatureManager.activated?(:db)
end
