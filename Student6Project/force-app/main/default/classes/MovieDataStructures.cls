public class MovieDataStructures {
    public class MovieJSON {
        public String id;
        public String name;
        public String tmdb_id;
        public String genre;
        public Double rating;
        public Decimal budget;
        public Decimal actual_budget;
        public Long revenue;
        public ScriptJSON script;
        public String release_date;
        public String status;
    }

    public class ScriptJSON {
        public String id;
        public String name;
        public String description;
    }
}
