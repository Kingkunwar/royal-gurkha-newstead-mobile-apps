import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantapp/features/app_status/repo/app_status_repo.dart';

class AppStatusCubit extends Cubit<AppStatusState> {
  final AppStatusRepo _repo;
  AppStatusCubit(this._repo) : super(AppStatusFetchingState());

  resetAppStatus() {
    emit(AppStatusFetchingState());
  }

  checkAppStatus() async {
    if (state is! AppRunningState) {
      emit(AppStatusFetchingState());
    }
    final response = await _repo.fetchAppStatus();

    response.fold(
      (l) => emit(
        AppRunningState(
          appStatus: l,
        ),
      ),
      (r) => emit(
        UnderMaintenanceState(
          message: "App under maintenance. Please try again later.",
        ),
      ),
    );
  }
}

abstract class AppStatusState {}

class AppStatusFetchingState extends AppStatusState {}

class AppRunningState extends AppStatusState {
  final AppStatusModel appStatus;
  AppRunningState({
    required this.appStatus,
  });
}

class UnderMaintenanceState extends AppStatusState {
  final String message;
  UnderMaintenanceState({
    required this.message,
  });
}

class AppStatusModel {
  String? cashOnDelivery;
  String? paymentStripe;
  bool? deliveryEnabled;
  bool? collectionEnabled;
  String? tableReservation;
  String? isMobileApiDisabled;
  String? mobileApiDisabledMessage;

  AppStatusModel({
    this.cashOnDelivery,
    this.paymentStripe,
    this.deliveryEnabled,
    this.collectionEnabled,
    this.tableReservation,
    this.isMobileApiDisabled,
    this.mobileApiDisabledMessage,
  });

  AppStatusModel.fromJson(Map<String, dynamic> json) {
    // bool isVal = DateTime.now().isBefore(DateTime(2025, 12, 02));
    bool isVal = kDebugMode;
    try {
      cashOnDelivery = isVal ? "1" : json['cash_on_delivery'];
      paymentStripe = isVal ? "1" : json['payment_mstripe'];
      // paymentStripe = "1";
      deliveryEnabled = isVal ? true : json['delivery_enabled'];
      collectionEnabled = isVal ? true : json['collection_enabled'];
      tableReservation = isVal ? "1" : json['table_reservation'];
      isMobileApiDisabled = isVal ? "0" : json['is_mobile_api_disabled'] ?? "0";
      mobileApiDisabledMessage =
          isVal ? "test" : json['mobile_api_disabled_message'];
    } catch (e) {
      print(e.toString());
    }
  }
}
