#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QDate>
#include <QIcon>
#include <QQmlContext>

#include <MauiKit3/Core/mauiapp.h>
#include <MauiKit3/Calendar/moduleinfo.h>

#include <KAboutData>
#include <KI18n/KLocalizedString>

#include "../project_version.h"

//Useful for setting quickly an app template
#define ORG_NAME "Maui"
#define PROJECT_NAME "Agenda"
#define COMPONENT_NAME "agenda"
#define PROJECT_DESCRIPTION "View and organize your events"
#define PROJECT_YEAR "2022"
#define CURRENT_PROJECT_YEAR "2023"
#define PRODUCT_NAME "maui/agenda"
#define PROJECT_PAGE "https://mauikit.org"
#define REPORT_PAGE "https://invent.kde.org/maui/index-fm/-/issues"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral(ORG_NAME));
    app.setWindowIcon(QIcon(":/logo.png"));

    KLocalizedString::setApplicationDomain(COMPONENT_NAME);

    KAboutData about(QStringLiteral(COMPONENT_NAME),
                     i18n(PROJECT_NAME),
                     PROJECT_VERSION_STRING,
                     i18n(PROJECT_DESCRIPTION),
                     KAboutLicense::LGPL_V3,
                     QString("© %1-%2 %3 Development Team").arg(PROJECT_YEAR, CURRENT_PROJECT_YEAR, ORG_NAME),
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));

    about.setHomepage(PROJECT_PAGE);
    about.setProductName(PRODUCT_NAME);
    about.setBugAddress(REPORT_PAGE);
    about.setOrganizationDomain(PROJECT_URI);
    about.setProgramLogo(app.windowIcon());

    about.addCredit(i18n("Kalendar Developers"));

    const auto AkonadiData = MauiKitCalendar::aboutAkonadi();
    about.addComponent(AkonadiData.name(), "", AkonadiData.version(), AkonadiData.webAddress());

    const auto CalData = MauiKitCalendar::aboutData();
    about.addComponent(CalData.name(), MauiKitCalendar::buildVersion(), CalData.version(), CalData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/logo.svg");

    QCommandLineParser parser;
    parser.setApplicationDescription(about.shortDescription());
    parser.process(app);
    about.processCommandLine(&parser);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
