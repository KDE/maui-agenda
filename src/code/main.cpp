#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QDate>
#include <QIcon>
#include <QQmlContext>

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/Calendar/moduleinfo.h>

#include <KAboutData>
#include <KLocalizedString>

#include "../project_version.h"

//Useful for setting quickly an app template
#define ORG_NAME "Maui"
#define PROJECT_NAME "Agenda"
#define COMPONENT_NAME "agenda"

#define PRODUCT_NAME "maui/agenda"
#define PROJECT_PAGE "https://mauikit.org"
#define REPORT_PAGE "https://invent.kde.org/maui/agenda/-/issues"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral(ORG_NAME));
    app.setWindowIcon(QIcon(":/logo.png"));

    KLocalizedString::setApplicationDomain(COMPONENT_NAME);

    KAboutData about(QStringLiteral(COMPONENT_NAME),
                     QStringLiteral(PROJECT_NAME),
                     PROJECT_VERSION_STRING,
                     i18n("View and organize your events"),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));

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

    const QUrl url(QStringLiteral("qrc:/app/maui/agenda/controls/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
