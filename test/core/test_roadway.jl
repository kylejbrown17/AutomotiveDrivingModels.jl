function get_test_roadway()
    roadway = Roadway()

    seg1 = RoadSegment(1,
        [Lane(LaneTag(1,1),
            [CurvePt(VecSE2(-2.0,0.0,0.0), 0.0),
             CurvePt(VecSE2(-1.0,0.0,0.0), 1.0)]),
         Lane(LaneTag(1,2),
            [CurvePt(VecSE2(-2.0,1.0,0.0), 0.0),
             CurvePt(VecSE2(-1.0,1.0,0.0), 1.0)]),
         Lane(LaneTag(1,3),
            [CurvePt(VecSE2(-2.0,2.0,0.0), 0.0),
             CurvePt(VecSE2(-1.0,2.0,0.0), 1.0)])
        ])

    seg2 = RoadSegment(2,
        [Lane(LaneTag(2,1),
            [CurvePt(VecSE2(0.0,0.0,0.0), 0.0),
             CurvePt(VecSE2(1.0,0.0,0.0), 1.0),
             CurvePt(VecSE2(2.0,0.0,0.0), 2.0),
             CurvePt(VecSE2(3.0,0.0,0.0), 3.0)]),
         Lane(LaneTag(2,2),
            [CurvePt(VecSE2(0.0,1.0,0.0), 0.0),
             CurvePt(VecSE2(1.0,1.0,0.0), 1.0),
             CurvePt(VecSE2(2.0,1.0,0.0), 2.0),
             CurvePt(VecSE2(3.0,1.0,0.0), 3.0)]),
         Lane(LaneTag(2,3),
            [CurvePt(VecSE2(0.0,2.0,0.0), 0.0),
             CurvePt(VecSE2(1.0,2.0,0.0), 1.0),
             CurvePt(VecSE2(2.0,2.0,0.0), 2.0),
             CurvePt(VecSE2(3.0,2.0,0.0), 3.0)])
         ])

    seg3 = RoadSegment(3,
        [Lane(LaneTag(3,1),
            [CurvePt(VecSE2(4.0,0.0,0.0), 0.0),
             CurvePt(VecSE2(5.0,0.0,0.0), 1.0)]),
         Lane(LaneTag(3,2),
            [CurvePt(VecSE2(4.0,1.0,0.0), 0.0),
             CurvePt(VecSE2(5.0,1.0,0.0), 1.0)]),
         Lane(LaneTag(3,3),
            [CurvePt(VecSE2(4.0,2.0,0.0), 0.0),
             CurvePt(VecSE2(5.0,2.0,0.0), 1.0)])
        ])

    for i in 1:3
        connect!(seg1.lanes[i], seg2.lanes[i])
        connect!(seg2.lanes[i], seg3.lanes[i])
    end

    push!(roadway.segments, seg1)
    push!(roadway.segments, seg2)
    push!(roadway.segments, seg3)

    roadway
end

let
    curve = get_test_curve1()

    lanetag = LaneTag(1,1)
    lane = Lane(lanetag, curve)

    @test !has_next(lane)
    @test !has_prev(lane)

    roadway = get_test_roadway()

    lane = roadway[LaneTag(1,1)]
    @test has_next(lane)
    @test !has_prev(lane)
    @test lane.next == LaneTag(2,1)

    lane = roadway[LaneTag(2,1)]
    @test has_next(lane)
    @test has_prev(lane)
    @test lane.next == LaneTag(3,1)
    @test lane.prev == LaneTag(1,1)

    res = proj(VecSE2(1.0,0.0,0.0), lane, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(1.5,0.25,0.1), lane, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.5)
    @test isapprox(res.curveproj.t, 0.25)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.tag

    res = proj(VecSE2(0.0,0.0,0.0), lane, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-0.75,0.0,0.0), lane, roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-1.75,0.0,0.0), lane, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.prev

    res = proj(VecSE2(4.25,0.2,0.1), lane, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(3.25,0.2,0.1), lane, roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(4.25,0.2,0.1), roadway[lane.prev], roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(-0.75,0.0,0.0), roadway[lane.next], roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    ####

    seg = roadway[2]

    res = proj(VecSE2(1.0,0.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(1.5,0.25,0.1), seg, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.5)
    @test isapprox(res.curveproj.t, 0.25)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.tag

    res = proj(VecSE2(0.0,0.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-0.75,0.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-1.75,0.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.prev

    res = proj(VecSE2(4.25,0.2,0.1), seg, roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(3.25,0.2,0.1), seg, roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(4.25,0.2,0.1), roadway[1], roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(-0.75,0.0,0.0), roadway[3], roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(1.0,1.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == LaneTag(2,2)

    res = proj(VecSE2(1.0,2.0,0.0), seg, roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == LaneTag(2,3)

    ###

    res = proj(VecSE2(1.0,0.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(1.5,0.25,0.1), roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.5)
    @test isapprox(res.curveproj.t, 0.25)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.tag

    res = proj(VecSE2(0.0,0.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-0.75,0.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(-1.75,0.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.prev

    res = proj(VecSE2(4.25,0.2,0.1), roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(3.25,0.2,0.1), roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(4.25,0.2,0.1), roadway[1], roadway)
    @test res.curveproj.ind == CurveIndex(1, 0.25)
    @test isapprox(res.curveproj.t, 0.2)
    @test isapprox(res.curveproj.ϕ, 0.1)
    @test res.tag == lane.next

    res = proj(VecSE2(-0.75,0.0,0.0), roadway[3], roadway)
    @test res.curveproj.ind == CurveIndex(0, 0.25)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == lane.tag

    res = proj(VecSE2(1.0,1.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == LaneTag(2,2)

    res = proj(VecSE2(1.0,2.0,0.0), roadway)
    @test res.curveproj.ind == CurveIndex(2, 0.0)
    @test isapprox(res.curveproj.t, 0.0)
    @test isapprox(res.curveproj.ϕ, 0.0)
    @test res.tag == LaneTag(2,3)

    ###

    roadind_0 = RoadIndex(CurveIndex(1,0), LaneTag(2,1))
    roadind = move_along(roadind_0, roadway, 0.0)
    @test roadind == roadind_0

    roadind = move_along(roadind_0, roadway, 1.0)
    @test roadind == RoadIndex(CurveIndex(2,0), LaneTag(2,1))

    roadind = move_along(roadind_0, roadway, 1.25)
    @test roadind == RoadIndex(CurveIndex(2,0.25), LaneTag(2,1))

    roadind = move_along(roadind_0, roadway, 3.0)
    @test roadind == RoadIndex(CurveIndex(3,1.0), LaneTag(2,1))

    roadind = move_along(roadind_0, roadway, 4.0)
    @test roadind == RoadIndex(CurveIndex(1,0.0), LaneTag(3,1))

    roadind = move_along(roadind_0, roadway, 4.5)
    @test roadind == RoadIndex(CurveIndex(1,0.5), LaneTag(3,1))

    roadind = move_along(roadind_0, roadway, 3.75)
    @test roadind == RoadIndex(CurveIndex(0,0.75), LaneTag(3,1))

    roadind = move_along(roadind_0, roadway, -1.0)
    @test roadind == RoadIndex(CurveIndex(0,0.0), LaneTag(2,1))

    roadind = move_along(roadind_0, roadway, -1.75)
    @test roadind == RoadIndex(CurveIndex(1,0.25), LaneTag(1,1))

    roadind = move_along(roadind_0, roadway, -0.75)
    @test roadind == RoadIndex(CurveIndex(0,0.25), LaneTag(2,1))
end