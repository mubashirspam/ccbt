// Survey endpoints
const String epSurvey = '/Survey';
const String epSurveyDelete = '/Survey/Delete';
const String epSurveyById = '/Survey';
const String epSurveyPage = '/Survey/Page';

const String epSurveyPageSort =
    '/Survey/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Question endpoints
const String epQuestion = '/Question';
const String epQuestionDelete = '/Question/Delete';
const String epQuestionById = '/Question';
const String epQuestionBySurvey = '/Question/Survey';
const String epQuestionByType = '/Question/QuestionType';
const String epQuestionByParent = '/Question/ParentQuestion';
const String epQuestionPage = '/Question/Page';
const String epQuestionPageSort =
    '/Question/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Answer Option endpoints
const String epAnswerOption = '/AnswerOption';
const String epAnswerOptionDelete = '/AnswerOption/Delete';
const String epAnswerOptionById = '/AnswerOption';
const String epAnswerOptionByQuestion = '/AnswerOption/Question';
const String epAnswerOptionPage = '/AnswerOption/Page';

const String epAnswerOptionPageSort =
    '/AnswerOption/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Response endpoints
const String epResponse = '/Response';
const String epResponseDelete = '/Response/Delete';
const String epResponseById = '/Response';
const String epResponseByParticipant = '/Response/Participant';
const String epResponseBySurvey = '/Response/Survey';
const String epResponsePage = '/Response/Page';
const String epResponsePageSort =
    '/Response/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Response Answers endpoints
const String epResponseAnswers = '/ResponseAnswers';
const String epResponseAnswersDelete = '/ResponseAnswers/Delete';
const String epResponseAnswersById = '/ResponseAnswers';
const String epResponseAnswersByQuestion = '/ResponseAnswers/Question';
const String epResponseAnswersByOption = '/ResponseAnswers/AnswerOption';
const String epResponseAnswersByResponse = '/ResponseAnswers/Response';
const String epResponseAnswersPage = '/ResponseAnswers/Page';
const String epResponseAnswersPageSort =
    '/ResponseAnswers/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Question Type endpoints
const String epQuestionType = '/QuestionType';
const String epQuestionTypeDelete = '/QuestionType/Delete';
const String epQuestionTypeById = '/QuestionType';
const String epQuestionTypePage = '/QuestionType/Page';
const String epQuestionTypePageSort =
    '/QuestionType/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Participant endpoints
const String epParticipant = '/Participant';
const String epParticipantDelete = '/Participant/Delete';
const String epParticipantById = '/Participant';
const String epParticipantByPerson = '/Participant/Person';
const String epParticipantPage = '/Participant/Page';
const String epParticipantPageSort =
    '/Participant/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Person endpoints
const String epPerson = '/Person';
const String epPersonDelete = '/Person/Delete';
const String epPersonById = '/Person';
const String epPersonPage = '/Person/Page';
const String epPersonPageSort =
    '/Person/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Grid Display endpoints
const String epGridDisplay = '/GridDisplay';
const String epGridDisplayByTag =
    '/GridDisplay/GridDisplayByTag'; // Add /{gridDisplay_tag}/Param1/{param1}/Param2/{param2}/Param3/{param3}

// AnswerOptionTemplate endpoints
const String epAnswerOptionTemplate = '/AnswerOptionTemplate';
const String epAnswerOptionTemplateDelete = '/AnswerOptionTemplate/Delete';
const String epAnswerOptionTemplateById = '/AnswerOptionTemplate';
const String epAnswerOptionTemplatePage = '/AnswerOptionTemplate/Page';
const String epAnswerOptionTemplatePageSort =
    '/AnswerOptionTemplate/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// AnswerOptionTemplateItem endpoints
const String epAnswerOptionTemplateItem = '/AnswerOptionTemplateItem';
const String epAnswerOptionTemplateItemDelete = '/AnswerOptionTemplateItem/Delete';
const String epAnswerOptionTemplateItemById = '/AnswerOptionTemplateItem';
const String epAnswerOptionTemplateItemByTemplateId = '/AnswerOptionTemplateItem/AnswerOptionTemplate';
const String epAnswerOptionTemplateItemPage = '/AnswerOptionTemplateItem/Page';
const String epAnswerOptionTemplateItemPageSort =
    '/AnswerOptionTemplateItem/Page'; // Add /{page}/Sort/{sortField}/Direction/{direction}

// Helper methods for constructing URLs with parameters
String createAnswerOptionFromTemplate(String templateId, String questionId) => '$epAnswerOption/$templateId/ToQuestion/$questionId';
String getByIdUrl(String base, String id) => '$base/$id';
String getDeleteUrl(String base, String id) => '$base/$id';
String getPageUrl(String base, int page) => '$base/$page';
String getPageSortUrl(
        String base, int page, String sortField, String direction) =>
    '$base/$page/Sort/$sortField/Direction/$direction';
String getGridDisplayTagUrl(String tag, String param1,
    [String? param2, String? param3]) {
  if (param3 != null && param2 != null) {
    return '$epGridDisplayByTag/$tag/Param1/$param1/Param2/$param2/Param3/$param3';
  } else if (param2 != null) {
    return '$epGridDisplayByTag/$tag/Param1/$param1/Param2/$param2';
  }
  return '$epGridDisplayByTag/$tag/Param1/$param1';
}
