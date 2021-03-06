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

BuildrPlus::Roles.role(:server) do
  if BuildrPlus::FeatureManager.activated?(:domgen)
    generators = [:ee_web_xml, :ee_beans_xml]
    if BuildrPlus::FeatureManager.activated?(:db)
      generators << [:jpa_dao_test]

      generators << [:imit_server_entity_replication] if BuildrPlus::FeatureManager.activated?(:gwt)
    end

    generators << [:gwt_rpc_shared, :gwt_rpc_server, :imit_shared, :imit_server_service, :imit_server_qa] if BuildrPlus::FeatureManager.activated?(:gwt)

    if BuildrPlus::FeatureManager.activated?(:sync)
      if BuildrPlus::Sync.standalone?
        generators << [:sync_ejb]
      else
        generators << [:sync_core_ejb]
      end
    end

    generators << [:ee_messages, :ee_exceptions, :ejb_service_facades, :ejb_test_qa, :ejb_test_service_test] if BuildrPlus::FeatureManager.activated?(:ejb)

    generators << [:xml_public_xsd_webapp] if BuildrPlus::FeatureManager.activated?(:xml)
    generators << [:jws_server, :ejb_glassfish_config_assets] if BuildrPlus::FeatureManager.activated?(:soap)

    Domgen::Build.define_generate_task(generators.flatten, :buildr_project => project)
  end

  project.publish = true

  # Our soap services use annotation for validation that is metro specific
  compile.with BuildrPlus::Libs.glassfish_embedded if BuildrPlus::FeatureManager.activated?(:soap)

  compile.with artifacts(Object.const_get(:PACKAGED_DEPS)) if Object.const_defined?(:PACKAGED_DEPS)

  BuildrPlus::Roles.merge_projects_with_role(project.compile, :model)
  BuildrPlus::Roles.merge_projects_with_role(project.test, :model_qa_support)

  test.with BuildrPlus::Libs.db_drivers

  package(:war).tap do |war|
    war.libs.clear
    war.libs << artifacts(Object.const_get(:PACKAGED_DEPS)) if Object.const_defined?(:PACKAGED_DEPS)
    BuildrPlus::Roles.buildr_projects_with_role(:shared).each do |dep|
      war.libs << dep.package(:jar)
    end
    BuildrPlus::Roles.buildr_projects_with_role(:model).each do |dep|
      war.libs << dep.package(:jar)
    end
    war.include assets.to_s, :as => '.' if BuildrPlus::FeatureManager.activated?(:gwt)
  end

  if BuildrPlus::FeatureManager.activated?(:gwt)
    check package(:war), 'should contain generated gwt artifacts' do
      it.should contain("#{project.root_project.name}/#{project.root_project.name}.nocache.js")
    end
  end

  iml.add_ejb_facet if BuildrPlus::FeatureManager.activated?(:ejb)
  if BuildrPlus::FeatureManager.activated?(:gwt)
    webroots = {}
    webroots[_(:source, :main, :webapp)] = '/'
    webroots[_(:source, :main, :webapp_local)] = '/'
    assets.paths.each { |path| webroots[path.to_s] = '/' unless path.to_s =~ /generated\/gwt\// }
    iml.add_web_facet(:webroots => webroots)
  else
    iml.add_web_facet
  end
end
