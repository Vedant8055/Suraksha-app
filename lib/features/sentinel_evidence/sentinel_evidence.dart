/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Feature Toggle & Settings (Phase 2)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

/// Public barrel for the Sentinel Evidence System module.
library;

export 'config/feature_flags.dart';
export 'config/sentinel_configuration.dart';
export 'constants/constants.dart';
export 'controllers/controllers.dart';
export 'controllers/sentinel_controller.dart';
export 'controllers/sentinel_permission_controller.dart';
export 'permissions/sentinel_readiness_checker.dart';
export 'storage/sentinel_permission_storage.dart';
export 'dependency/sentinel_dependency_injection.dart';
export 'exceptions/sentinel_exceptions.dart';
export 'interfaces/interfaces.dart';
export 'models/models.dart';
export 'navigation/sentinel_navigator.dart';
export 'repository/repository.dart';
export 'screens/screens_module.dart';
export 'sentinel_entry_point.dart';
export 'services/services.dart';
export 'state/sentinel_control_state.dart';
export 'state/sentinel_state.dart';
export 'storage/sentinel_settings_storage.dart';
export 'utils/utils.dart';
export 'widgets/sentinel_profile_card.dart';
export 'widgets/sentinel_scaffold.dart';
export 'widgets/sentinel_test_mode_banner.dart';
