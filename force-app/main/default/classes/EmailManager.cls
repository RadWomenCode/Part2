/*
Source Code:https://trailhead.salesforce.com/en/content/learn/modules/apex_triggers/apex_triggers_intro
*/
public class EmailManager {
    // Public method
    public static void sendMail(String address, String subject, String body) {
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>{ address };
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // Pass this email message to the built-in sendEmail method
        // of the Messaging class
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ mail }
        );

        // Call a helper method to inspect the returned results
        inspectResults(results);
    }

    // Helper method
    private static Boolean inspectResults(
        List<Messaging.SendEmailResult> results
    ) {
        Boolean sendResult = true;

        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results.
        // In this class, the methods send only one email,
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                sendResult = false;
                System.debug(
                    'The following errors occurred: ' + res.getErrors()
                );
            }
        }

        return sendResult;
    }
}
