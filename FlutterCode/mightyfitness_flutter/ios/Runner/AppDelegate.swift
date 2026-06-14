import UIKit
import Flutter
import GoogleMobileAds
import google_mobile_ads

class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {

  func createNativeAd(_ nativeAd: GADNativeAd,
                      customOptions: [AnyHashable : Any]?) -> GADNativeAdView {

    let adView = GADNativeAdView(frame: .zero)
    adView.translatesAutoresizingMaskIntoConstraints = false
    adView.backgroundColor = .white

    // Main vertical container
    let container = UIStackView()
    container.axis = .vertical
    container.spacing = 10
    container.translatesAutoresizingMaskIntoConstraints = false
    container.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    container.isLayoutMarginsRelativeArrangement = true
    adView.addSubview(container)

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      container.topAnchor.constraint(equalTo: adView.topAnchor),
      container.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
    ])

    // MARK: - Top Row (Horizontal)
    let topRow = UIStackView()
    topRow.axis = .horizontal
    topRow.alignment = .center
    topRow.spacing = 12
    topRow.translatesAutoresizingMaskIntoConstraints = false

    // Icon (48x48 like Android)
    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFill
    iconView.clipsToBounds = true
    iconView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 48).isActive = true

    // Text Column
    let textColumn = UIStackView()
    textColumn.axis = .vertical
    textColumn.spacing = 4
    textColumn.translatesAutoresizingMaskIntoConstraints = false

    // Headline (16 bold, 1 line)
    let headlineLabel = UILabel()
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
    headlineLabel.textColor = .black
    headlineLabel.numberOfLines = 1
    headlineLabel.lineBreakMode = .byTruncatingTail

    // Sponsored label (12pt, gray)
    let sponsoredLabel = UILabel()
    sponsoredLabel.text = "Sponsored"
    sponsoredLabel.font = UIFont.systemFont(ofSize: 12)
    sponsoredLabel.textColor = UIColor.gray

    textColumn.addArrangedSubview(headlineLabel)
    textColumn.addArrangedSubview(sponsoredLabel)

    // CTA Button (36 height, orange like Android)
    let ctaButton = UIButton(type: .system)
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.backgroundColor = UIColor(red: 236/255, green: 126/255, blue: 74/255, alpha: 1.0)
    ctaButton.layer.cornerRadius = 4
    ctaButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    ctaButton.isUserInteractionEnabled = false

    // Add to top row
    topRow.addArrangedSubview(iconView)
    topRow.addArrangedSubview(textColumn)
    topRow.addArrangedSubview(ctaButton)

    textColumn.setContentHuggingPriority(.defaultLow, for: .horizontal)
    ctaButton.setContentHuggingPriority(.required, for: .horizontal)

    container.addArrangedSubview(topRow)

    // MARK: - Media View (160 height like Android)
    let mediaView = GADMediaView()
    mediaView.translatesAutoresizingMaskIntoConstraints = false
    mediaView.heightAnchor.constraint(equalToConstant: 160).isActive = true
    mediaView.contentMode = .scaleAspectFill
    mediaView.clipsToBounds = true

    container.addArrangedSubview(mediaView)

    // MARK: - Assign Native Ad Views
    adView.iconView = iconView
    adView.headlineView = headlineLabel
    adView.callToActionView = ctaButton
    adView.mediaView = mediaView

    headlineLabel.text = nativeAd.headline

    if let icon = nativeAd.icon?.image {
      iconView.image = icon
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }

    if let cta = nativeAd.callToAction {
      ctaButton.setTitle(cta, for: .normal)
      ctaButton.isHidden = false
    } else {
      ctaButton.isHidden = true
    }

    adView.nativeAd = nativeAd

    return adView
  }
}

class BannerNativeAdFactory: NSObject, FLTNativeAdFactory {

  func createNativeAd(_ nativeAd: GADNativeAd,
                      customOptions: [AnyHashable : Any]?) -> GADNativeAdView {

    let adView = GADNativeAdView(frame: .zero)
    adView.translatesAutoresizingMaskIntoConstraints = false
    adView.backgroundColor = .white

    // Fixed height like Android (180dp ≈ 180pt)
    adView.heightAnchor.constraint(equalToConstant: 180).isActive = true

    // Main horizontal container
    let container = UIStackView()
    container.axis = .horizontal
    container.spacing = 12
    container.alignment = .center
    container.translatesAutoresizingMaskIntoConstraints = false
    container.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    container.isLayoutMarginsRelativeArrangement = true
    adView.addSubview(container)

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      container.topAnchor.constraint(equalTo: adView.topAnchor),
      container.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
    ])

    // MARK: - Left Image (100x100)
    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFill
    iconView.clipsToBounds = true
    iconView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 100).isActive = true

    // MARK: - Right Vertical Content
    let rightColumn = UIStackView()
    rightColumn.axis = .vertical
    rightColumn.spacing = 8
    rightColumn.translatesAutoresizingMaskIntoConstraints = false
    rightColumn.alignment = .fill
    rightColumn.distribution = .equalSpacing

    // Headline (16 bold, 1 line)
    let headlineLabel = UILabel()
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
    headlineLabel.textColor = .black
    headlineLabel.numberOfLines = 1
    headlineLabel.lineBreakMode = .byTruncatingTail

    // Body (13pt, 2 lines, gray)
    let bodyLabel = UILabel()
    bodyLabel.font = UIFont.systemFont(ofSize: 13)
    bodyLabel.textColor = UIColor.darkGray
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byTruncatingTail

    // CTA Button (40 height, full width, orange)
    let ctaButton = UIButton(type: .system)
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.backgroundColor = UIColor(
      red: 236/255,
      green: 126/255,
      blue: 74/255,
      alpha: 1.0
    )
    ctaButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    ctaButton.layer.cornerRadius = 4
    ctaButton.isUserInteractionEnabled = false

    rightColumn.addArrangedSubview(headlineLabel)
    rightColumn.addArrangedSubview(bodyLabel)
    rightColumn.addArrangedSubview(ctaButton)


    container.addArrangedSubview(iconView)
    container.addArrangedSubview(rightColumn)

    // MARK: - Assign Native Ad Assets
    adView.headlineView = headlineLabel
    adView.bodyView = bodyLabel
    adView.iconView = iconView
    adView.callToActionView = ctaButton

    headlineLabel.text = nativeAd.headline

    if let body = nativeAd.body {
      bodyLabel.text = body
      bodyLabel.isHidden = false
    } else {
      bodyLabel.isHidden = true
    }

    if let icon = nativeAd.icon?.image {
      iconView.image = icon
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }

    if let cta = nativeAd.callToAction {
      ctaButton.setTitle(cta, for: .normal)
      ctaButton.isHidden = false
    } else {
      ctaButton.isHidden = true
    }

    adView.nativeAd = nativeAd

    return adView
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {

  var listTileNativeAdFactory: ListTileNativeAdFactory?
  var bannerNativeAdFactory: BannerNativeAdFactory?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    listTileNativeAdFactory = ListTileNativeAdFactory()
    bannerNativeAdFactory = BannerNativeAdFactory()

    if let listTileNativeAdFactory {
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "listTile",
        nativeAdFactory: listTileNativeAdFactory
      )
    }

    if let bannerNativeAdFactory {
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self,
        factoryId: "bannerTile",
        nativeAdFactory: bannerNativeAdFactory
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
