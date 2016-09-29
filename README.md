#CAWIML (Computer Assisted Web Interviewing Markup Language)

CAWIML is an XML language to describe electronic questionnaires. This authoring solution uses XSD (XML Schema Definition) to define structure and datatypes together with SCH (Schematron) to express integrity constraints and business rules.

Using two different XML schema solutions help this language to ensure the correctness of XML electronic questionnaire instances through a tow step process that integrate the four different levels of validation (structure, datatypes, integrity constraints and business rules).

Any XML instance conforming to CAWIML must define the following 5 categories:

1. *survey* : defines the global information relative to a questionnaire and contains information such as name, description and date for a survey.
2. *content* : specifies questions that are grouped within sections. It provides support for the most common types such as intro statement, single, multiple choice, open and grid questions.
3. *field* : defines placeholders variables needed to share information across different questionnaire sections. Currently, there are four types supported (string, integer, decimal and list).
4. *routing* : captures questionnaire's flow using a state-transition structure.
5. *personalisation*: defines constructs to adapt questionnaires for each interview through features such as text-fill, carry-forward, randomising or rotating.


