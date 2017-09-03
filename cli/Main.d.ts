interface Renderer {
    name: string;
    extension: string;
    aceMode: string;
    // it's not really `any`, just not exposed to TS
    options: {[name: string]: any};
}

type SourceCode = string;
type ErrorMessage = string;

interface Main {
    renderers: Renderer[];
    main(options: {[name: string]: string}): ((config: Config) => Either<ErrorMessage, SourceCode>);
    urlsFromJsonGrammar(json: object): Either<string, { [key: string]: string[] }>;
    intSentinel: string;
}

type Json = object;
type IRTypeable = Json | string;

type TopLevelConfig = 
     | { name: string; samples: IRTypeable[]; }
     | { name: string; schema: Json; };

interface Config {
    language: string;
    topLevels: TopLevelConfig[];     
}