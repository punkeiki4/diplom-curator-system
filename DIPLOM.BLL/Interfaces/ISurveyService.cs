using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface ISurveyService
{
    Task<IEnumerable<SurveyDto>> GetAllAsync();
    Task<SurveyDto?> GetByIdAsync(int id);
    Task<SurveyDto> CreateAsync(CreateSurveyDto dto);
    Task<bool> DeleteAsync(int id);
    Task<IEnumerable<SurveyAnswerDto>> GetAnswersAsync(int surveyId);
    Task<SurveyAnswerDto> SubmitAnswerAsync(CreateSurveyAnswerDto dto);
}
