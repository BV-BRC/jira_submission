module JiraSubmission {
    typedef structure  {
	string key;
	string url;
	string status;
    } Issue;
    funcdef submit_bug(string summary, string description, string website_version, string webpage_url) returns (Issue issue) authentication optional;
    funcdef submit_task_failure(string summary, string description, string website_version, string webpage_url, string task_id) returns (Issue issue) authentication optional;
};
