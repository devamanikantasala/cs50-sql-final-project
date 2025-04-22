CREATE INDEX "students_enrolled_index"
ON "enrollments"("student_id");

CREATE INDEX "enrolled_course_index"
ON "enrollments"("course_id");

CREATE INDEX "course_departs_nums_sems_index"
ON "courses"("department", "number", "semester");

CREATE INDEX "course_semester_index"
ON "courses"("semester");

CREATE INDEX "course_departs_and_sems_index"
ON "courses"("department", "semester");

CREATE INDEX "course_title_and_semester_index"
ON "courses"("title", "semester");

CREATE INDEX "satisfied_course_index"
ON "satisfies"("course_id");

