import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/site_visit.dart';
import 'package:budowapro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String contactKindLabel(AppLocalizations l10n, ContactKind value) =>
    switch (value) {
      ContactKind.person => l10n.contactKindPerson,
      ContactKind.company => l10n.contactKindCompany,
    };

String contactRoleLabel(AppLocalizations l10n, ContactRole value) =>
    switch (value) {
      ContactRole.generalContractor => l10n.contactRoleGeneralContractor,
      ContactRole.siteManager => l10n.contactRoleSiteManager,
      ContactRole.architect => l10n.contactRoleArchitect,
      ContactRole.electrician => l10n.contactRoleElectrician,
      ContactRole.plumber => l10n.contactRolePlumber,
      ContactRole.heatingAndVentilation => l10n.contactRoleHeatingVentilation,
      ContactRole.surveyor => l10n.contactRoleSurveyor,
      ContactRole.roofer => l10n.contactRoleRoofer,
      ContactRole.carpenter => l10n.contactRoleCarpenter,
      ContactRole.plasterer => l10n.contactRolePlasterer,
      ContactRole.tiler => l10n.contactRoleTiler,
      ContactRole.painter => l10n.contactRolePainter,
      ContactRole.supplier => l10n.contactRoleSupplier,
      ContactRole.inspector => l10n.contactRoleInspector,
      ContactRole.other => l10n.contactRoleOther,
    };

IconData contactRoleIcon(ContactRole value) => switch (value) {
  ContactRole.electrician => Icons.electrical_services_outlined,
  ContactRole.plumber ||
  ContactRole.heatingAndVentilation => Icons.plumbing_outlined,
  ContactRole.architect => Icons.architecture_outlined,
  ContactRole.siteManager ||
  ContactRole.generalContractor => Icons.engineering_outlined,
  ContactRole.surveyor => Icons.straighten_outlined,
  ContactRole.roofer => Icons.roofing_outlined,
  ContactRole.supplier => Icons.local_shipping_outlined,
  ContactRole.inspector => Icons.fact_check_outlined,
  _ => Icons.handyman_outlined,
};

String siteVisitStatusLabel(AppLocalizations l10n, SiteVisitStatus value) =>
    switch (value) {
      SiteVisitStatus.planned => l10n.siteVisitStatusPlanned,
      SiteVisitStatus.completed => l10n.siteVisitStatusCompleted,
      SiteVisitStatus.cancelled => l10n.siteVisitStatusCancelled,
      SiteVisitStatus.noShow => l10n.siteVisitStatusNoShow,
    };

Color siteVisitStatusColor(ColorScheme colors, SiteVisitStatus value) =>
    switch (value) {
      SiteVisitStatus.planned => colors.primary,
      SiteVisitStatus.completed => colors.tertiary,
      SiteVisitStatus.cancelled => colors.outline,
      SiteVisitStatus.noShow => colors.error,
    };
