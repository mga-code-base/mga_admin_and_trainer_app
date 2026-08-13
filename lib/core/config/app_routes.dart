import 'package:flutter/material.dart';
import '../../screens/common/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/primary_admin_setup_screen.dart';
import '../../screens/auth/signup_admin_tabs_screen.dart';
import '../../screens/auth/signup_trainer_screen.dart';
import '../../screens/admin/admin_home_screen.dart';
import '../../screens/admin/primary_admin_home_screen.dart';
import '../../screens/admin/active_grievances_screen.dart';
import '../../screens/admin/all_branches_screen.dart';
import '../../screens/admin/approve_admins_screen.dart';
import '../../screens/admin/approve_members_screen.dart';
import '../../screens/admin/approve_trainers_screen.dart';
import '../../screens/admin/branch_equipments_screen.dart';
import '../../screens/admin/add_equipment_screen.dart';
import '../../screens/admin/deactivate_trainer_screen.dart';
import '../../screens/admin/get_member_screen.dart';
import '../../screens/admin/my_branch_details_screen.dart';
import '../../screens/trainer/trainer_home_screen.dart';
import '../../screens/trainer/trainer_branch_screen.dart';
import '../../screens/trainer/trainer_details_screen.dart';
import '../../screens/trainer/trainer_trainees_screen.dart';
import '../../screens/trainer/trainee_progress_screen.dart';
import '../../screens/common/notifications_feed_screen.dart';
import '../../screens/common/publish_notification_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String primaryAdminSetup = '/primary-admin-setup';
  static const String signupAdmin = '/signup-admin';
  static const String signupTrainer = '/signup-trainer';

  static const String adminHome = '/admin-home';
  static const String primaryAdminHome = '/primary-admin-home';
  static const String activeGrievances = '/active-grievances';
  static const String allBranches = '/all-branches';
  static const String approveAdmins = '/approve-admins';
  static const String approveMembers = '/approve-members';
  static const String approveTrainers = '/approve-trainers';
  static const String branchEquipments = '/branch-equipments';
  static const String addEquipment = '/add-equipment';
  static const String deactivateTrainer = '/deactivate-trainer';
  static const String getMember = '/get-member';
  static const String myBranchDetails = '/my-branch-details';

  static const String trainerHome = '/trainer-home';
  static const String trainerBranch = '/trainer-branch';
  static const String trainerDetails = '/trainer-details';
  static const String trainerTrainees = '/trainer-trainees';
  static const String traineeProgress = '/trainee-progress';

  static const String notificationsFeed = '/notifications-feed';
  static const String publishNotification = '/publish-notification';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        primaryAdminSetup: (_) => const PrimaryAdminSetupScreen(),
        signupAdmin: (_) => const SignupAdminTabsScreen(),
        signupTrainer: (_) => const SignupTrainerScreen(),
        adminHome: (_) => const AdminHomeScreen(),
        primaryAdminHome: (_) => const PrimaryAdminHomeScreen(),
        activeGrievances: (_) => const ActiveGrievancesScreen(),
        allBranches: (_) => const AllBranchesScreen(),
        approveAdmins: (_) => const ApproveAdminsScreen(),
        approveMembers: (_) => const ApproveMembersScreen(),
        approveTrainers: (_) => const ApproveTrainersScreen(),
        branchEquipments: (_) => const BranchEquipmentsScreen(),
        addEquipment: (_) => const AddEquipmentScreen(),
        deactivateTrainer: (_) => const DeactivateTrainerScreen(),
        getMember: (_) => const GetMemberScreen(),
        myBranchDetails: (_) => const MyBranchDetailsScreen(),
        trainerHome: (_) => const TrainerHomeScreen(),
        trainerBranch: (_) => const TrainerBranchScreen(),
        trainerDetails: (_) => const TrainerDetailsScreen(),
        trainerTrainees: (_) => const TrainerTraineesScreen(),
        traineeProgress: (_) => const TraineeProgressScreen(),
        notificationsFeed: (_) => const NotificationsFeedScreen(),
        publishNotification: (_) => const PublishNotificationScreen(),
      };
}
